Setup
  $ . ${TESTDIR}/../setup.sh
  $ . ${TESTDIR}/setup.sh $(pwd) ./monorepo
# Build app-a, save output to a file so we can fish out the hash from the logs
# - Should not run compile task, since dependsOn is overridden.
# - Should write files to `lib/` directory, since `outputs` is overriden.
  $ ${TURBO} run build --skip-infer --filter=app-a > tmp.log
  $ cat tmp.log
  \xe2\x80\xa2 Packages in scope: app-a (esc)
  \xe2\x80\xa2 Running build in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  app-a:build: cache miss, executing a2b07de4bacfb060
  app-a:build: 
  app-a:build: > build
  app-a:build: > echo "building app-a" > lib/foo.txt && echo "building app-a" > out/foo.txt
  app-a:build: 
  
   Tasks:    1 successful, 1 total
  Cached:    0 cached, 1 total
    Time:\s*[\.0-9]+m?s  (re)
  
# Look in the saved logs for the hash, so we can inspect the tarball with the same name
  $ HASH=$(cat tmp.log | grep -E "app-a:build.* executing .*" | awk '{print $5}')
  $ tar -tf $TARGET_DIR/node_modules/.cache/turbo/$HASH.tar.zst;
  apps/app-a/.turbo/turbo-build.log
  apps/app-a/lib/
  apps/app-a/lib/.keep
  apps/app-a/lib/foo.txt

# Build app-b, save output to a file so we can fish out the hash from logs
# - Should run `compile` first.
# - Should write files to `out/` directory
  $ ${TURBO} run build --skip-infer --filter=app-b > tmp.log
  $ cat tmp.log
  \xe2\x80\xa2 Packages in scope: app-b (esc)
  \xe2\x80\xa2 Running build in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  app-b:compile: cache miss, executing 01d3f7fb171b09fb
  app-b:compile: 
  app-b:compile: > compile
  app-b:compile: > echo "compiling in app-b"
  app-b:compile: 
  app-b:compile: compiling in app-b
  app-b:build: cache miss, executing 467753c1b0a50790
  app-b:build: 
  app-b:build: > build
  app-b:build: > echo "building app-b" > lib/foo.txt && echo "building app-b" > out/foo.txt
  app-b:build: 
  
   Tasks:    2 successful, 2 total
  Cached:    0 cached, 2 total
    Time:\s*[\.0-9]+m?s  (re)
  
# Look in the saved logs for the hash, so we can inspect the tarball with the same name
  $ HASH=$(cat tmp.log | grep -E "app-b:build.* executing .*" | awk '{print $5}')
  $ tar -tf $TARGET_DIR/node_modules/.cache/turbo/$HASH.tar.zst;
  apps/app-b/.turbo/turbo-build.log
  apps/app-b/out/
  apps/app-b/out/.keep
  apps/app-b/out/foo.txt

# Build app-c, save output to a file so we can fish out the hash from logs
# - Should run `compile` first, even though there is a turbo.json override
# TODO(mehulkar) app-c:compile is get a cache bypass instead of miss right now, figure out why.
  $ ${TURBO} run build --skip-infer --filter=app-c > tmp.log
  $ cat tmp.log
  \xe2\x80\xa2 Packages in scope: app-c (esc)
  \xe2\x80\xa2 Running build in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  app-c:compile: cache miss, executing 881137e47d3fdf98
  app-c:compile: 
  app-c:compile: > compile
  app-c:compile: > echo "compiling in app-c"
  app-c:compile: 
  app-c:compile: compiling in app-c
  app-c:build: cache miss, executing 790724ee3c6be8dd
  app-c:build: 
  app-c:build: > build
  app-c:build: > echo "building app-c" > lib/foo.txt && echo "building app-c" > out/foo.txt
  app-c:build: 
  
   Tasks:    2 successful, 2 total
  Cached:    0 cached, 2 total
    Time:\s*[\.0-9]+m?s  (re)
  

# Build app-d, save output to a file so we can fish out the hash from logs
# - Should run `compile` first, even though there is a turbo.json override
  $ ${TURBO} run build --skip-infer --filter=app-d > tmp.log
  $ cat tmp.log
  \xe2\x80\xa2 Packages in scope: app-d (esc)
  \xe2\x80\xa2 Running build in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  app-d:beforecompile: cache miss, executing f52145f1e3314679
  app-d:beforecompile: 
  app-d:beforecompile: > beforecompile
  app-d:beforecompile: > echo "beforecompiling in app-d"
  app-d:beforecompile: 
  app-d:beforecompile: beforecompiling in app-d
  app-d:compile: cache miss, executing 49e62230be3e592b
  app-d:compile: 
  app-d:compile: > compile
  app-d:compile: > echo "compiling in app-d"
  app-d:compile: 
  app-d:compile: compiling in app-d
  app-d:build: cache miss, executing 06edaa94ec275a10
  app-d:build: 
  app-d:build: > build
  app-d:build: > echo "building app-d" > lib/foo.txt && echo "building app-d" > out/foo.txt
  app-d:build: 
  
   Tasks:    3 successful, 3 total
  Cached:    0 cached, 3 total
    Time:\s*[\.0-9]+m?s  (re)
  