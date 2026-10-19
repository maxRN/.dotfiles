"""Freeze Paper Mono's OpenType `zero` feature into a separately named family."""

from pathlib import Path
import sys

from fontTools.ttLib import TTFont


FAMILY = "Paper Mono Slashed Zero"
POSTSCRIPT_FAMILY = "PaperMonoSlashedZero"


def rename(value):
    return value.replace("Paper Mono", FAMILY).replace("PaperMono", POSTSCRIPT_FAMILY)


def patch(source, destination):
    font = TTFont(source, recalcTimestamp=False)
    original_cmap = font.getBestCmap().copy()
    gsub = font["GSUB"].table
    substitutions = {}
    for feature in gsub.FeatureList.FeatureRecord:
        if feature.FeatureTag == "zero":
            for index in feature.Feature.LookupListIndex:
                lookup = gsub.LookupList.Lookup[index]
                # The pinned release uses single substitutions. Fail on changes
                # rather than silently generating an unmodified font.
                assert lookup.LookupType == 1, "Unsupported zero substitution"
                for subtable in lookup.SubTable:
                    substitutions.update(subtable.mapping)

    zero = original_cmap[ord("0")]
    assert zero in substitutions, "Missing slashed-zero substitution"
    slashed_zero = substitutions[zero]
    assert slashed_zero != zero

    for table in font["cmap"].tables:
        if table.isUnicode():
            table.cmap = {
                codepoint: substitutions.get(glyph, glyph)
                for codepoint, glyph in table.cmap.items()
            }

    # Include legacy, typographic, WWS, unique and PostScript names so macOS
    # keeps this family separate from the upstream fonts in every weight.
    for record in font["name"].names:
        if record.nameID in (1, 3, 4, 6, 16, 18, 21, 25):
            record.string = rename(record.toUnicode()).encode(record.getEncoding())

    cff = font["CFF "].cff
    cff.fontNames = [rename(name) for name in cff.fontNames]
    top = cff.topDictIndex[0]
    top.FamilyName = rename(top.FamilyName)
    top.FullName = rename(top.FullName)
    font.save(destination)
    font.close()

    # Verify the serialized font, not just the in-memory changes.
    with TTFont(destination) as result:
        assert result.getBestCmap() == {
            codepoint: substitutions.get(glyph, glyph)
            for codepoint, glyph in original_cmap.items()
        }
        for table in result["cmap"].tables:
            if table.isUnicode():
                assert table.cmap[ord("0")] == slashed_zero
        assert result["name"].getDebugName(1).startswith(FAMILY)
        assert result["name"].getDebugName(6).startswith(POSTSCRIPT_FAMILY)
        assert result["CFF "].cff.topDictIndex[0].FamilyName == FAMILY
    print(f"{source.name}: {zero} -> {slashed_zero}")


source_dir, destination_dir = map(Path, sys.argv[1:])
destination_dir.mkdir(parents=True, exist_ok=True)
fonts = sorted(source_dir.glob("*.otf"))
assert len(fonts) == 8, "Expected all eight Paper Mono weights"
for source in fonts:
    patch(source, destination_dir / source.name.replace("PaperMono", POSTSCRIPT_FAMILY))
