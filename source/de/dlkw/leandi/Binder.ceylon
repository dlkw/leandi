import ceylon.language.meta.model {
    ClassOrInterface,
    Class
}


shared interface Binder
{
    shared formal BindingBuilder<Iface> bind<Iface>(ClassOrInterface<Iface> classOrInterface, String? variant = null)
            given Iface satisfies Object;

    shared formal BindingBuilder<Iface> rebind<Iface>(ClassOrInterface<Iface> classOrInterface, String? variant = null)
            given Iface satisfies Object;
}

shared interface BindingBuilder<Iface>
        given Iface satisfies Object
{
    shared formal BindingBuilder<Iface> to<I>(Class<I> klass, Scope scope = singleton) given I satisfies Iface;
    shared formal BindingBuilder<Iface> toInstance(Iface instance);
}
