#!/bin/bash


readonly python="~/git/reservoir_sampling/reservoir_sampling/reservoir_sampling.py"
readonly sample_size=1000
readonly src=${1:-$PORTAGE/corpora/bac-lac.2021/bitextor_2018/201808/permanent/en-fr.deduped.txt.gz}

cargo build --release
zcat --force $src | head -500000 > benches/src.txt
hyperfine \
   --shell bash \
   --export-json hyperfine.text.json \
   --style full \
   --parameter-list sample_size 1000,10000,100000 \
   "$python --size {sample_size} < benches/src.txt" \
   "cargo run --release unweighted --size {sample_size} < benches/src.txt" \
   "$python --size {sample_size} benches/src.txt <(cut -f 8 < benches/src.txt)" \
   "cargo run --release weighted --size {sample_size} benches/src.txt <(cut -f 8 < benches/src.txt)" \
   | tee \
   > hyperfine.text.json.results
rm benches/src.txt
