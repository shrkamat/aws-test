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
* To update aws-sdk-cpp version modify [./deps/BuildDeps.cmake +60](https://github.com/skamath/aws-http/blob/46e1842abc33390eb3d8c897d0ed0b437f75040c/deps/BuildDeps.cmake#L59-L60) however it will require clean build use `git clean -fdx` to clear build artifacts.
