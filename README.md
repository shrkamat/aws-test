# AWS SDK with openssl 1.0.2u

### Prerequisites
- install terraform
- install aws cli
- install cmake

### Configure aws credentials
```
aws Configure
```
> **Note**
> Use region `ap-south-1`. If any other region is to be used correspondingly code will have to be edited too (here)[https://github.com/shrkamat/aws-test/blob/4e0440a3bc86f01b04d799d02104ad91fb647c80/main.cpp#L56].

### Create Kinesis stream
```
cd kinesis-stream
terraform init
terraform apply
```

### Build & Run steps
```bash
make deps && make
# env to load openssl 1.0.2u
source devenv
gdb ./build/bin/aws-test
(gdb) start
(gdb) continue
```

#### Info
* To update aws-sdk-cpp version modify [./deps/BuildDeps.cmake +58](https://github.com/shrkamat/aws-test/blob/296e4243ad8cc2571860e8d51899ddff60664057/deps/BuildDeps.cmake#L58) however it will require clean build use `git clean -fdx` to clear build artifacts.
