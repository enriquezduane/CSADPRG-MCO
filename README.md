## MCO1 

### To build the docker iamge

```
docker build -t mco1 .
```

### To run the docker image

```
docker run -it mco1 /bin/bash
```

## MCO2

### To build the docker image (might take a while apprx 10 mins)

```
docker build -t mco2 .
```

### To run the docker image

```
docker run -it -v $(pwd):/app mco2 /bin/bash
```

Note: The above command will mount the current directory to the container.
