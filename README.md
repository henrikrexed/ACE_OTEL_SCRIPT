# OpenTelemetry Training Deployment scripe

This repository will contains all the scripts to deploy the otel training environment
This repository is based on 2 popular Demo platform provided  :
- The Online Boutique
- Otel-demo

**Online Boutique** is a cloud-native microservices demo application.
Online Boutique consists of a 10-tier microservices application. The application is a
web-based e-commerce app where users can browse items,
add them to the cart, and purchase them.
The Google HipsterShop is a microservice architecture using several langages :
* Go 
* Python
* Nodejs
* C#
* Java
  dt0c01.RWUC4RSXGBRJFWITBJ3PPCZ6.I6XACEKFCQ3XH73WECPALGKNWUTJNP4PZL2QXANOI52DNJJG4VDVLAI2JKTLQREO
  https://dtmanaged.dynatrace.training/e/fa88e26d-66ca-4db2-b809-e3f62c737c3c

## Prerequisite
The following tools need to be install on your machine :

- jq
- kubectl
- git
- helm

## Getting started locally

### Quick Start with k3d

First of all, build the demo image:

```bash
make build
```

Then, run the demo:

```bash
make run
```





