# Yetamine ServiceBox

ServiceBox is a minimalistic, yet feature-rich OSGi Framework distribution.


## Overview

ServiceBox is *not* an OSGi Framework implementation.
What it is then?

* It is an OSGi Framework distribution based on well-known and proven implementations of the OSGi specifications and focused to provide a minimal set of widely useful specifications (which is opinionated, of course).
* It is an extension of [YOFL](http://github.com/yetamine/net.yetamine.osgi.launcher), a vendor-neutral launcher, that defines conventions for making framework distributions and provides a default distribution based on these conventions out of the box.

ServiceBox might be an interesting alternative to other distributions for a few reasons:

* **Features needed for most applications are ready out of the box:**
Almost all applications need some configuration, logging facilities or depend on other services and need to connect with them.
ServiceBox provides support for these frequent demands by providing features like *Configuration Admin Service* and *Declarative Services* out of the box.

* **Vendor-neutral:**
Thanks to YOFL, ServiceBox provides a vendor-neutral façade for the OSGi Framework implementation.
Changing even the framework implementation is therefore quite easy.

* **Domain-neutral:**
ServiceBox prefers no particular application style.
Instead, it provides a set of rather universal facilities that are widely useful.

* **Extensible:**
Thanks to the compact, domain-neutral core, ServiceBox is a good a base for domain-specific distributions and/or various applications.
For instance, when developing a lot of similar RESTful services, the developer can choose the suitable RESTful stack and make a ServiceBox distribution for deploying all the services in a uniform way.

* **Light and small:**
Thanks to the limited set of features, ServiceBox remains still relatively small, although it provides powerful features for developing truly modular applications.
For instance, a trivial JAX-RS application exposing a JSON API can fit into less than 10 MB of heap space, which is close to the realm of various micro frameworks, but with the full power of the OSGi Framework available.

* **Container-friendly:**
Leveraging the extensible nature of ServiceBox leads naturally to using ServiceBox and/or with varying feature sets as the base layer for making application images.
YOFL's support for pre-deployment of the OSGi runtime can help then to reduce the image size and startup times.

* **Experiment-friendly:**
Because it is easy to make a custom framework distribution and launch different distributions based on different framework implementations in the same way, it is easy to experiment and compare an application behaviour with different frameworks.

Interested?
Try it out!


## Getting started

ServiceBox is actually a thin layer around YOFL that defines the layout of a framework distribution.

A framework distribution organized according to the defined layout, so called kit, can be used in the same way, no matter which framework implementation it employs.
The concept of the kit makes the use of ServiceBox significantly simpler than using YOFL directly, although it preserves its core principles like being vendor-neutral.
ServiceBox shares even the command line syntax with YOFL.

Assuming that `./bundles` directory contains the bundles of an OSGi application, this command makes ServiceBox deploy the application into `./instance` directory and start it with the default framework distribution:

```bash
servicebox --bundles ./bundles ./instance
```

Assuming that `./alternative-kit` contains an alternative kit with a different framework implementation, launching the same application with that framework implementation needs just setting an environment variable to point to the alternative kit:

```bash
SERVICEBOX_KIT=./alternative-kit servicebox --bundles ./bundles ./instance
```

ServiceBox can be embedded in an OSGi application distribution easily as well.
When `my-application` is an application with the layout assumed by the bundled launch scripts for applications, the application can be launched with the scripts without changing them:

```bash
my-application/launch ./instance
```

More details are available in the documentation bundled in ServiceBox distribution.


## Licensing ##

The project is licensed under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0). Contributions to the project are welcome and accepted if they can be incorporated without the need of changing the license or license conditions and terms.


[![Yetamine logo](https://github.com/yetamine/yetamine.github.io/raw/master/brand/light/Yetamine_logo_opaque_100x28.png "Our logo")](https://github.com/yetamine/yetamine.github.io/blob/master/brand/light/Yetamine_logo_opaque.svg)
