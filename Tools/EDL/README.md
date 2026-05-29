# EDL (Emergency Download for Qualcomm)

## Linux

Add the Python PPA and install Python 3.14:

```
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install python3.14
```

Then run EDL with:

```
python3.14 edl.py w <partition> <image>.img --loader=8110.mbn
```

## Windows

Use EDL directly from the `edl` directory. No additional setup needed.

```
python edl.py w <partition> <image>.img --loader=8110.mbn
```

## Flashing an image

```
python edl.py w <partition> <image>.img --loader=8110.mbn
```

Replace `<partition>` with the partition name and `<image>.img` with the image file you want to flash.
