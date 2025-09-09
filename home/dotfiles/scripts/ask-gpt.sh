#!/usr/bin/env bash

echo -n "Ask Gemini: "
read question

open "https://t3.chat/new?model=gemini-2.5-flash&q=$question"
