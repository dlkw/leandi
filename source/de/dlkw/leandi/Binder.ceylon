import ceylon.language.meta.model {
    ClassOrInterface,
    Class
}


shared interface Binder
{
    "Creates a `BindingBuilder that can bind a class or interface with an optional variant to implementing classes or instances.
     If the class or interface is already bound, a `BindingException` will be thrown."
    shared formal BindingBuilder<Iface> bind<Iface>(ClassOrInterface<Iface> classOrInterface, String? variant = null)
            given Iface satisfies Object;

    "Creates a `BindingBuilder that can bind a class or interface with an optional variant to implementing classes or instances.
     If the class or interface is already bound, the previous binding will be discarded. It is allowed to call this
     method even when the class or interface is not bound yet."
    shared formal BindingBuilder<Iface> rebind<Iface>(ClassOrInterface<Iface> classOrInterface, String? variant = null)
            given Iface satisfies Object;
}

shared interface BindingBuilder<Iface>
        given Iface satisfies Object
{
    "Binds to a toplevel class using a Scope. The class needs a parameter list or a default constructor."
    shared formal BindingBuilder<Iface> to<I>(Class<I> klass, Scope scope = singleton) given I satisfies Iface;

    "Binds to an instance."
    shared formal BindingBuilder<Iface> toInstance(Iface instance);
}
