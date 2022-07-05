# AWS SDK with openssl 1.0.2u

### Build & Run steps
```bash
make deps && make
# env to load openssl 1.0.2p
source devenv
gdb ./build/bin/aws-test
(gdb) start
(gdb) continue
```

#### Info
* To update aws-sdk-cpp version modify [./deps/BuildDeps.cmake +58](https://github.com/shrkamat/aws-test/blob/296e4243ad8cc2571860e8d51899ddff60664057/deps/BuildDeps.cmake#L58) however it will require clean build use `git clean -fdx` to clear build artifacts.
