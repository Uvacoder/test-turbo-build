Setup
  $ . ${TESTDIR}/../setup.sh
  $ . ${TESTDIR}/setup.sh $(pwd) ./monorepo

# The missing-workspace-config-task task in the root turbo.json has config. The workspace config
# does not have a turbo.json. The tests below use `missing-workspace-config-task` to assert that:
# - `outputs`, `inputs`, `env` are retained from the root.

# 1. First run, assert for `outputs`
  $ ${TURBO} run missing-workspace-config-task --skip-infer --filter=missing-workspace-config > tmp.log
  $ cat tmp.log
  \xe2\x80\xa2 Packages in scope: missing-workspace-config (esc)
  \xe2\x80\xa2 Running missing-workspace-config-task in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  missing-workspace-config:missing-workspace-config-task: cache miss, executing e3f005fb9046f408
  missing-workspace-config:missing-workspace-config-task: 
  missing-workspace-config:missing-workspace-config-task: > missing-workspace-config-task
  missing-workspace-config:missing-workspace-config-task: > echo "running missing-workspace-config-task" > out/foo.min.txt
  missing-workspace-config:missing-workspace-config-task: 
  
   Tasks:    1 successful, 1 total
  Cached:    0 cached, 1 total
    Time:\s*[\.0-9]+m?s  (re)
  
  $ HASH=$(cat tmp.log | grep -E "missing-workspace-config:missing-workspace-config-task.* executing .*" | awk '{print $5}')
  $ tar -tf $TARGET_DIR/node_modules/.cache/turbo/$HASH.tar.zst;
  apps/missing-workspace-config/.turbo/turbo-missing-workspace-config-task.log
  apps/missing-workspace-config/out/
  apps/missing-workspace-config/out/.keep
  apps/missing-workspace-config/out/foo.min.txt

2. Run again and assert cache hit, and that output is suppressed
  $ ${TURBO} run missing-workspace-config-task --skip-infer --filter=missing-workspace-config
  \xe2\x80\xa2 Packages in scope: missing-workspace-config (esc)
  \xe2\x80\xa2 Running missing-workspace-config-task in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  missing-workspace-config:missing-workspace-config-task: cache hit, suppressing output e3f005fb9046f408
  
   Tasks:    1 successful, 1 total
  Cached:    1 cached, 1 total
    Time:\s*[\.0-9]+m?s >>> FULL TURBO (re)
  
3. Change input file and assert cache miss, and not FULL TURBO
  $ echo "more text" >> $TARGET_DIR/apps/missing-workspace-config/src/foo.txt
  $ ${TURBO} run missing-workspace-config-task --skip-infer --filter=missing-workspace-config
  \xe2\x80\xa2 Packages in scope: missing-workspace-config (esc)
  \xe2\x80\xa2 Running missing-workspace-config-task in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  missing-workspace-config:missing-workspace-config-task: cache miss, executing c59cd8e812e43c61
  missing-workspace-config:missing-workspace-config-task: 
  missing-workspace-config:missing-workspace-config-task: > missing-workspace-config-task
  missing-workspace-config:missing-workspace-config-task: > echo "running missing-workspace-config-task" > out/foo.min.txt
  missing-workspace-config:missing-workspace-config-task: 
  
   Tasks:    1 successful, 1 total
  Cached:    0 cached, 1 total
    Time:\s*[\.0-9]+m?s  (re)
  

3a. Changeing a different file (that is not in `inputs` config) gets cache hit and FULL TURBO
  $ echo "more text" >> $TARGET_DIR/apps/missing-workspace-config/src/bar.txt
  $ ${TURBO} run missing-workspace-config-task --skip-infer --filter=missing-workspace-config
  \xe2\x80\xa2 Packages in scope: missing-workspace-config (esc)
  \xe2\x80\xa2 Running missing-workspace-config-task in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  missing-workspace-config:missing-workspace-config-task: cache hit, suppressing output c59cd8e812e43c61
  
   Tasks:    1 successful, 1 total
  Cached:    1 cached, 1 total
    Time:\s*[\.0-9]+m?s >>> FULL TURBO (re)
  
4. Set env var and assert cache miss, and that hash is different from above
  $ SOME_VAR=somevalue ${TURBO} run missing-workspace-config-task --skip-infer --filter=missing-workspace-config
  \xe2\x80\xa2 Packages in scope: missing-workspace-config (esc)
  \xe2\x80\xa2 Running missing-workspace-config-task in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  missing-workspace-config:missing-workspace-config-task: cache miss, executing e6352de4007857ae
  missing-workspace-config:missing-workspace-config-task: 
  missing-workspace-config:missing-workspace-config-task: > missing-workspace-config-task
  missing-workspace-config:missing-workspace-config-task: > echo "running missing-workspace-config-task" > out/foo.min.txt
  missing-workspace-config:missing-workspace-config-task: 
  
   Tasks:    1 successful, 1 total
  Cached:    0 cached, 1 total
    Time:\s*[\.0-9]+m?s  (re)
  