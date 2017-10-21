import ceylon.language.meta.model {
    ClassOrInterface
}


shared interface Injector
{
    "Provides an instance of an interface or class as configured."
    shared formal Iface instance<Iface>(ClassOrInterface<Iface> key, String? variant = null)
            given Iface satisfies Object;
}

shared Injector createInjector(Anything(Binder) bindings) => InjectorImpl(bindings);

"Provides an instance of class `Instance`, using an `Injector` for dependencies."
shared interface Provider<out Instance>
        given Instance satisfies Object
{
    shared formal Instance provide(Injector injector);
}

shared class BindingException(String description)
        extends Exception(description){}
