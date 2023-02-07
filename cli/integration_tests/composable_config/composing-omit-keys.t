Setup
  $ . ${TESTDIR}/../setup.sh
  $ . ${TESTDIR}/setup.sh $(pwd) ./monorepo

# The omit-keys-task task in the root turbo.json has ALL the config. The workspace config
# defines the task, but does not override any of the keys. The tests below use `omit-keys-task`
to assert that
# - `outputs`, `inputs`, `env` are retained from the root.
# These tests use a different task from the ones above because
# tasks with dependencies have side effects and can have cache
# misses because of those dependencies. These tests attempt to isolate
# for inputs and env changes.

# 1. First run, assert for `outputs`
  $ ${TURBO} run omit-keys-task --skip-infer --filter=omit-keys > tmp.log
  $ cat tmp.log
  \xe2\x80\xa2 Packages in scope: omit-keys (esc)
  \xe2\x80\xa2 Running omit-keys-task in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  omit-keys:omit-keys-task: cache miss, executing c94d786c6090d542
  omit-keys:omit-keys-task: 
  omit-keys:omit-keys-task: > omit-keys-task
  omit-keys:omit-keys-task: > echo "running omit-keys-task" > out/foo.min.txt
  omit-keys:omit-keys-task: 
  
   Tasks:    1 successful, 1 total
  Cached:    0 cached, 1 total
    Time:\s*[\.0-9]+m?s  (re)
  
  $ HASH=$(cat tmp.log | grep -E "omit-keys:omit-keys-task.* executing .*" | awk '{print $5}')
  $ tar -tf $TARGET_DIR/node_modules/.cache/turbo/$HASH.tar.zst;
  apps/omit-keys/.turbo/turbo-omit-keys-task.log
  apps/omit-keys/out/
  apps/omit-keys/out/.keep
  apps/omit-keys/out/foo.min.txt

2. Run again and assert cache hit, and that output is suppressed
  $ ${TURBO} run omit-keys-task --skip-infer --filter=omit-keys
  \xe2\x80\xa2 Packages in scope: omit-keys (esc)
  \xe2\x80\xa2 Running omit-keys-task in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  omit-keys:omit-keys-task: cache hit, suppressing output c94d786c6090d542
  
   Tasks:    1 successful, 1 total
  Cached:    1 cached, 1 total
    Time:\s*[\.0-9]+m?s >>> FULL TURBO (re)
  
3. Change input file and assert cache miss, and not FULL TURBO
  $ echo "more text" >> $TARGET_DIR/apps/omit-keys/src/foo.txt
  $ ${TURBO} run omit-keys-task --skip-infer --filter=omit-keys
  \xe2\x80\xa2 Packages in scope: omit-keys (esc)
  \xe2\x80\xa2 Running omit-keys-task in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  omit-keys:omit-keys-task: cache miss, executing e5a4f86dd3cef193
  omit-keys:omit-keys-task: 
  omit-keys:omit-keys-task: > omit-keys-task
  omit-keys:omit-keys-task: > echo "running omit-keys-task" > out/foo.min.txt
  omit-keys:omit-keys-task: 
  
   Tasks:    1 successful, 1 total
  Cached:    0 cached, 1 total
    Time:\s*[\.0-9]+m?s  (re)
  

3a. Changeing a different file (that is not in `inputs` config) gets cache hit and FULL TURBO
  $ echo "more text" >> $TARGET_DIR/apps/omit-keys/src/bar.txt
  $ ${TURBO} run omit-keys-task --skip-infer --filter=omit-keys
  \xe2\x80\xa2 Packages in scope: omit-keys (esc)
  \xe2\x80\xa2 Running omit-keys-task in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  omit-keys:omit-keys-task: cache hit, suppressing output e5a4f86dd3cef193
  
   Tasks:    1 successful, 1 total
  Cached:    1 cached, 1 total
    Time:\s*[\.0-9]+m?s >>> FULL TURBO (re)
  
4. Set env var and assert cache miss, and that hash is different from above
  $ SOME_VAR=somevalue ${TURBO} run omit-keys-task --skip-infer --filter=omit-keys
  \xe2\x80\xa2 Packages in scope: omit-keys (esc)
  \xe2\x80\xa2 Running omit-keys-task in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  omit-keys:omit-keys-task: cache miss, executing e545e31a0389e12a
  omit-keys:omit-keys-task: 
  omit-keys:omit-keys-task: > omit-keys-task
  omit-keys:omit-keys-task: > echo "running omit-keys-task" > out/foo.min.txt
  omit-keys:omit-keys-task: 
  
   Tasks:    1 successful, 1 total
  Cached:    0 cached, 1 total
    Time:\s*[\.0-9]+m?s  (re)
  