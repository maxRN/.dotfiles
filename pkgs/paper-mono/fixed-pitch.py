"""Mark Paper Mono as fixed-pitch so macOS lists it in monospace font pickers."""

from pathlib import Path
import sys

from fontTools.ttLib import TTFont


source_dir, destination_dir = map(Path, sys.argv[1:])
destination_dir.mkdir(parents=True, exist_ok=True)
fonts = sorted(source_dir.glob("*.otf"))
assert len(fonts) == 8, "Expected all eight Paper Mono weights"

for source in fonts:
    destination = destination_dir / source.name
    with TTFont(source, recalcTimestamp=False) as font:
        original_cmap = font.getBestCmap().copy()
        original_metrics = font["hmtx"].metrics.copy()
        # Upstream's PANOSE already says monospaced, but macOS needs these
        # fixed-pitch flags too. Leave glyph outlines and advance widths intact.
        font["post"].isFixedPitch = 1
        font["CFF "].cff.topDictIndex[0].isFixedPitch = 1
        font.save(destination)

    with TTFont(destination) as result:
        assert result["post"].isFixedPitch == 1
        assert result["CFF "].cff.topDictIndex[0].isFixedPitch == 1
        assert result.getBestCmap() == original_cmap
        assert result["hmtx"].metrics == original_metrics
    print(f"{source.name}: fixed-pitch metadata enabled")
