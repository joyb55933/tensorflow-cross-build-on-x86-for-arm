# tensorflow-cross-build-on-x86-for-arm
follow this guide, you can cross build tensorflow framework on X86 for arm and aarch64 platform。
copyright@joy.deng@nxp.com

1. you should have one X86 machine that installed with ubuntu OS,

2. import the based docker image base-x86-os.tar on your x86 host
   docker import - base-x86-os < base-x86-os.tar

3. run the dockerfile to build tensorflow automatically
   docker run build -t your-image-name --network=host .

4. after the build suceessfully, you can get the tensorflow wheel package on your local directory.





