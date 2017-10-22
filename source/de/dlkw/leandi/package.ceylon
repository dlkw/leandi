"""
   An injector is created via a call to `createInjector`, passing a `bindings` function
   argument.
   
   Use repeated calls of `Binder` calls in the `bindings` function to setup
   the injection dependencies, like
   ```
      (binder) => {
          binder.bind(`InterfaceA`).to(`ImplementationA`);
          binder.bind(`InterfaceB`).to(`ImplementationB`, noScope);
          // etc...
      }
   ```
   A class may be bound to itself if it doesn't satisfy an interface.
   
   A class or interface may be bound to a toplevel class or an instance.
   
   You can then call the injector's `instance` method to obtain an instance for a
   particular interface (and optional variant). When the interface is bound to an instance,
   that will be returned. When it is bound to a class, the instance from the scope is returned.
   In case no instance in the scope has been created yet,
   a new instance will be created and added to the scope.
   
   When using implementation classes with parameters (or a default constructor with parameters),
   each class or interface that appears as parameter type must also be bound to an implementation.
   The injector uses itself to create arguments for these parameters (using no variant).
   If argument creation leads to a cyclic dependency, a `BindingException` is thrown.
"""
shared package de.dlkw.leandi;
