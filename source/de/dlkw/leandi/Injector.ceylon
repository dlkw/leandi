import ceylon.language.meta.model {
    ClassOrInterface
}


"""
   A dependency injector. Create an instance using the `createInjector` toplevel function. 
"""
shared interface Injector
{
    "Provides an instance of an interface or class as configured."
    shared formal Iface instance<Iface>(ClassOrInterface<Iface> key, String? variant = null)
            given Iface satisfies Object;
}

"Creates an injector from bindings. See package description."
shared Injector createInjector(Anything(Binder) bindings) => InjectorImpl(bindings);

shared class BindingException(String description)
        extends Exception(description){}
