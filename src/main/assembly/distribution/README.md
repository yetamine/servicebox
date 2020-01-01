# Yetamine ServiceBox

ServiceBox is a minimalistic, yet feature-rich OSGi Framework distribution.


## Introduction

ServiceBox is *not* an OSGi Framework implementation.
What it is then?

* It is an OSGi Framework distribution based on well-known and proven implementations of the OSGi specifications and focused to provide a minimal set of widely useful specifications (which is opinionated, of course).
* It is an extension of [YOFL](http://github.com/yetamine/net.yetamine.osgi.launcher), a vendor-neutral launcher, that defines conventions for making framework distributions and provides a default distribution based on these conventions out of the box.

Therefore ServiceBox can be used as it is, out of the box, or it can be used as the wireframe for building a completely custom distribution.


## Getting started

ServiceBox is actually a thin layer around YOFL that defines the layout of a framework distribution and provides a few launch scripts.
Using these scripts is significantly simpler than using YOFL directly, because the scripts can derive many parameters required for YOFL from the distribution layout.
On the other hand, the use resembles YOFL a lot, even the command line parameters are identical.

Assuming that `./bundles` directory contains the bundles of an OSGi application, this command makes ServiceBox deploy the application into `./instance` directory and start it with the default framework distribution:

```bash
servicebox --bundles ./bundles ./instance
```


## Launch scripts

The example above already introduced `servicebox` script.
The script performs following operations, which the user would have to take care manually when using YOFL directly:

* It composes the boot class path with the framework implementation.
* It supplies the default system and framework properties.
* It supplies the defaults for YOFL and the bundle store with the core bundles.
* It provides optionally the options for JPMS (Java Platform Module System) required by the framework implementation when running with Java 9 or newer.
* And finally, it applies application-specific configuration if provided.

However, ServiceBox offers three launch scripts:

1. `servicepad`: Starts YOFL with a framework distribution, but without any additional bundles (so it is the right choice when needing almost bare YOFL).
2. `servicebox`: Starts YOFL *launch* command with a framework distribution.
3. `serviceapp`: Starts a ServiceBox application, which will be explained later.

As the list hints, `servicepad` is the lowest-level script that configures YOFL to be able to start a bare framework and passes all its arguments to YOFL.


### Environment variables

The scripts use an interface based on environment variables and pass all command line arguments directly to the launcher. This approach seems to be more robust and portable than attempts to process command line arguments partially.

On the other hand, using environment variables impose a risk that must be understood and taken into account: some of the variables determine the code to execute in the future, therefore never run the scripts without controlling the variables.

Both `servicepad` and `servicebox` commands use following variables:

* **`JAVA`:**
The command to launch JVM.
Default assumes `java` command available from the `PATH` environment variable.

* **`JAVA_OPTS`:**
Additional Java runtime options passed to the `JAVA` command.
This variables must contain only arguments that need no shell escaping as it expands to multiple arguments and shells typically handle such a situation poorly.
Tuning options, for instance heap limits, are typically passed via this variable.
Java 9 introduces the `JDK_JAVA_OPTIONS` environment variable and argument files, which allows work around the `JAVA_OPTS` limitations.

* **`SERVICEBOX_AUTOPATH`:**
The path to the directory which shall be scanned for the `.jar` files to be added to the boot class path.
Note that only the files contained directly in the specified directory are found and their order on the resulting class path depends on the operating system.
Despite of the limitations, this variable makes class path composition much easier for typical cases.

* **`SERVICEBOX_BOOTPATH`:**
The class path to be appended to the boot class path.
Unlike `SERVICEBOX_AUTOPATH`, this variable is an actual class path fragment, and therefore does not suffer from the same limitations.
It is appended to the final class path before `SERVICEBOX_AUTOPATH`.

* **`SERVICEBOX_KIT`:**
The name of the ServiceBox kit to pick, depending on `SERVICEBOX_KIT_PATH`.
If `SERVICEBOX_KIT_PATH` is empty, built-in kits are considered; if both
variables are empty, `default` built-in kit is chosen.

* **`SERVICEBOX_KIT_PATH`:**
The path to the ServiceBox kit location.
If empty, a built-in kit shall be used according to `SERVICEBOX_KIT`.
Otherwise the combination of both variables result in the location of the target kit.

* **`YOFL_LOGGING_FILE`:**
The desired output stream for the launcher logger.
The value may be `stdout` or `stderr` (the default) for standard process file handles, or a file name.
In the case of the file name, the target path must be accessible for write and the file is overwritten.
Note that while `stdout` prints to the standard output, `./stdout` prints to the file with the name of `stdout` in the current working directory.

* **`YOFL_LOGGING_LEVEL`:**
The logging level for the launcher logger.
The value may be `FORCE`, `ERROR` (the default), `WARN`, `INFO` or `DEBUG`.
The launcher reports only severe errors by default and forced output (see `--dump-status` option) to the standard error handle, so that YOFL can be used for applications that produce their actual output to standard output without affecting it.

`SERVICEBOX_AUTOPATH` and `SERVICEBOX_BOOTPATH` are not supported by `servicepad`, instead **`SERVICEBOX_APP`** variable should be set to contain the directory where the ServiceBox application to launch should be used (if not set, the current working directory is used by default).

Following sections will explain the terms *kit* and *application* that appeared in the list above.

## ServiceBox kits

A ServiceBox kit is a framework distribution, i.e., the framework implementation with additional bundles, organized according to the layout defined below, so that ServiceBox could treat various framework distributions in the same way.


### A kit layout

A kit must have contain this structure:

```
boot/                       # Contains .jar files placed on the class path
  classes/                  # Placed on the class path before the .jar files
  jpms.options              # Options for JPMS (optional)

core/                       # Bundle store

etc/
  framework.properties
  launching.properties
  system.properties
```

The framework implementation with any other libraries required for the framework itself should be placed in `boot/`, which YOFL uses to extend its own class path where the framework implementation is searched for.

Because the class path looks like `boot/classes/:boot/*.jar`, all resources placed in `boot/classes/` are considered first and therefore effectively override resources from `boot/*.jar`.
This is useful for placing any loose resources that should be easy to edit, like default configuration files (a frequent case for logging systems), and that must take precedence over the resources embedded in the `.jar` files.

If the framework implementation needs specific options for JPMS (Java Platform Module System), it is possible to place these options in `boot/jpms.options`, which is passed as an argument file to the Java launcher.

The bundles that should be deployed to framework instances are expected in `core/`.
This location is used as a bundle store, i.e., it should contain subdirectories with the bundles and optional `deployment.properties` that supply configuration options for particular subdirectory.

Finally, `etc/` must contain files dedicated for all three kinds of properties that YOFL distinguishes.
The files have obvious names: `framework.properties`, `launching.properties` and `system.properties`.

It is not required, but it is recommended to place important informative resources in the root of the kit, e.g., `README.md` with the kit description, `LICENSE` with legal information and `NOTICE` with a summary and contacts.


### Using a kit

ServiceBox launch scripts consult `SERVICEBOX_KIT_PATH` and `SERVICEBOX_KIT` environment variables to determine the location of the kit to use.
If `SERVICEBOX_KIT_PATH` is empty, a built-in kit shall be used and `SERVICEBOX_KIT` tells the name of the kit (`default` is used if empty), otherwise `SERVICEBOX_KIT` is appended to it and the result it used as the kit location.

Here comes the notion of built-in kits: a ServiceBox distribution can actually contain multiple built-in kits.
All the built-in kits are placed in `kits/` directory in the ServiceBox distribution root directory and the default built-in kit is located in `kits/default/`.

Setting `SERVICEBOX_KIT_PATH` allows using other kits than built-in.
Note that the variable should contain an absolute path, otherwise the location depends on the current directory, which usually leads to wrong and confusing results.

However, let's assume that `SERVICEBOX_KIT_PATH` is set properly, so that ServiceBox shall choose a kit from the location with kits for a couple of different framework implementation:

```
kits/
  concierge/
  equinox/
  felix/
  knopflerfish/
```

Then we can run an application with a particular framework (e.g., Eclipse Equinox) like this:

```bash
SERVICEBOX_KIT=equinox servicebox --bundles ./bundles ./instance
```


## ServiceBox applications

A ServiceBox application is an extension running on the top of a ServiceBox distribution.
The application contains just the application-specific parts, while it relies on the ServiceBox distribution to supply the common parts.
An application can be launched in a simple way with `serviceapp` script.


### An application layout

The application layout is an extension of the kit layout:

```
boot/                       # Contains .jar files placed on the class path
  classes/                  # Placed on the class path before the .jar files
  jpms.options              # Options for JPMS

conf/                       # Configuration for newly created instances
core/                       # Bundle store with the application core

etc/
  framework.properties
  launching.properties
  system.properties

sys/                        # Embedded ServiceBox distribution
launch                      # Launch script for the application
```

Required items are `conf/`, `core/` and `etc/*`, remaining items are optional and additional items may appear, e.g., `doc/`, `README.*`, `LICENSE` or `NOTICE`.

The launch script(s), conventionally named `launch` (with platform-specific name variants), are recommended, so that users can launch the application without knowing anything about underlying details.
The launch scripts can employ `serviceapp` to handle most of the heavy-lifting, which reduces their duty to setting up the environment variables and locating the ServiceBox distribution to use.
The default embedded ServiceBox distribution should be then placed in `sys/`.


### Running an application

A ServiceBox application can be launched with `serviceapp` script easily.
The script uses `SERVICEBOX_APP` environment variable to get the location of the application to launch.
The variable must point to the application (directory).
All arguments are then passed to the underlying ServiceBox commands (and ultimately to YOFL).

Assuming that the application resides in `./app`, following command deploys it in `./instance` and starts it:

```bash
SERVICE_APP=./app serviceapp ./instance
```

A convenient `launch` script in the application distribution can be used to make it even shorter and more natural:

```bash
./app/launch ./instance
```
