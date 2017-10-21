import ceylon.collection {
    LinkedList,
    HashMap
}

import ceylon.language.meta.model {
    ClassOrInterface,
    Class
}

class Key(ClassOrInterface<Object> type, String? variant = null)
{
    shared actual Boolean equals(Object other)
    {
        value e = eq(other);
        //print("is ``this`` equals ``other``? ``e``");
        return e;
    }
    
    Boolean eq(Object other)
    {
        if (!is Key other) {
            return false;
        }
        else {
            if (type != other.type) {
                return false;
            }
            if (is Null variant) {
                return other.variant is Null;
            }
            if (exists ov = other.variant) {
                return variant == ov;
            }
            return false;
        }
    }
    
    shared actual Integer hash{
        value hh = h;
        //print("calc hash for ``this``: ``hh``");
        return hh;
    }
    Integer h
    {
        return type.hash + (if (exists variant) then 31 * variant.hash else 0);
    }
    
    shared actual String string => type.string + (if (exists variant) then " (``variant``)" else "");
}


class InjectorImpl(Anything(Binder) bindings)
        satisfies Injector
{
    value providers = HashMap<Key, Provider<Object>>();
    
    void putProvider<IfaceType>(Key key, Provider<IfaceType> provider, Boolean allowOverride)
            given IfaceType satisfies Object
    {
        if (!allowOverride && providers.get(key) exists) {
            throw BindingException("Key ``key`` already bound, use explicit override.");
        }
        providers.put(key, provider);
    }
    
    class CycleCheckingInjector()
            satisfies Injector
    {
        value stack = LinkedList<Key>();
        
        void push(Key key)
        {
            if (stack.contains(key)) {
                throw BindingException("Cycle detected");
            }
            stack.insert(0, key);
        }
 
        void pop() => stack.deleteFirst();

        shared actual Iface instance<Iface>(ClassOrInterface<Iface> classOrInterface, String? variant)
                given Iface satisfies Object
        {
            value key = Key(classOrInterface, variant);
            push(key);
            try {
                value provider = providers.get(key);
                if (is Null provider) {
                    throw BindingException("Key ``key`` not bound");
                }
                value result = provider.provide(this);
                // unfortunately, the following assert may be expensive :-(
                assert (is Iface result);
                return result;
            }
            finally {
                pop();
            }
        }
    }
    
    shared actual Iface instance<Iface>(ClassOrInterface<Iface> key, String? variant)
            given Iface satisfies Object
        => CycleCheckingInjector().instance(key, variant);
    
    class BindingBuilderImpl<IfaceType>(Key key, Boolean allowOverride)
            satisfies BindingBuilder<IfaceType>
            given IfaceType satisfies Object
    {
        shared actual BindingBuilder<IfaceType> to<Instance>(Class<Instance> implementation, Scope scope)
                given Instance satisfies IfaceType
        {
            value provider = scope.scoped(implementation, ConstructorProvider(implementation));
            putProvider(key, provider, allowOverride);
            return this;
        }
        
        shared actual BindingBuilder<IfaceType> toInstance(IfaceType instance)
        {
            value provider = InstanceProvider(instance);
            putProvider(key, provider, allowOverride);
            return this;
        }
    }
    
    class BinderImpl()
            satisfies Binder
    {
        shared actual BindingBuilder<Iface> bind<Iface>(ClassOrInterface<Iface> classOrInterface, String? variant)
                given Iface satisfies Object
            => doBind(classOrInterface, variant, false);

        shared actual BindingBuilder<Iface> rebind<Iface>(ClassOrInterface<Iface> classOrInterface, String? variant)
                given Iface satisfies Object
            => doBind(classOrInterface, variant, true);
        
        BindingBuilder<Iface> doBind<Iface>(ClassOrInterface<Iface> type, String? variant, Boolean allowOverride)
                given Iface satisfies Object
           => BindingBuilderImpl<Iface>(Key(type, variant), allowOverride);
    }
    
    value binder = BinderImpl();
    
    bindings(binder);
}
