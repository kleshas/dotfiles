#!/bin/bash
cd ~/.cache/wal
nohup python -m http.server 8000 &
