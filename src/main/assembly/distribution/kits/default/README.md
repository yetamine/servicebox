# Default ServiceBox kit

The default [ServiceBox](http://github.com/yetamine/servicebox) kit supplies following OSGi specifications and services:

* OSGi R7 Framework
* OSGi R7 Core specifications, except for *Conditional Permission Admin Service*
* OSGi R7 Compendium specifications:
    * *Configuration Admin Service*
    * *Configurator*
    * *Converter*
    * *Coordinator Service*
    * *Declarative Services*
    * *Event Admin Service*
    * *Log Service*
    * *Metatype Service*
    * *Promises*
    * *Push Stream*

Following implementations were used:

* [Apache Felix](http://felix.apache.org/)
* [PAX Logging](https://github.com/ops4j/org.ops4j.pax.logging)
* Official OSGi resources for the utilities specifications

PAX Logging provides support for the most common logging frameworks, besides the Log Service.
