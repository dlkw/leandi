import ceylon.test {
    test,
    assertThatException,
    assertIs,
    assertEquals,
    assertNotEquals
}

import de.dlkw.leandi {
    createInjector,
    BindingException,
    noScope,
    singleton,
    Module,
    Binder,
    Injector
}


shared class StdTest()
{
    Injector oldSingleCreateInjector(Anything(Binder) singleBindings) => createInjector(object satisfies Module
        {
            shared actual void bindings(Binder binder) => singleBindings(binder);
        });
    
    test
    shared void notBoundRaisesException() {
        interface IA{}

        value injector = oldSingleCreateInjector((binder)
        {
            
        });
        
        assertThatException(()=>injector.instance(`IA`)).hasType(`BindingException`);
    }

    test
    shared void boundInterfaceReturnsInstanceFromClassWithParameters() {
        
        value injector = oldSingleCreateInjector((binder)
        {
            binder.bind(`IA`).to(`A`);
        });
        
        value instance = injector.instance(`IA`);
        assertIs(instance, `A`);
    }
    
    test
    shared void boundInterfaceReturnsInstanceFromClassWithDefaultConstructor() {
        
        value injector = oldSingleCreateInjector((binder)
            {
            binder.bind(`IA`).to(`A2`);
        });
        
        value instance = injector.instance(`IA`);
        assertIs(instance, `A2`);
    }
    
    test
    shared void boundInterfaceReturnsInstanceFromClassWithUnsharedDefaultConstructor() {
        
        oldSingleCreateInjector((binder)
        {
            assertThatException(()=>binder.bind(`IA`).to(`A3`)).hasType(`BindingException`);
        });
    }
    
    test
    shared void boundInterfaceReturnsInstanceFromClassWithoutDefaultConstructor() {
        
        oldSingleCreateInjector((binder)
        {
            assertThatException(()=>binder.bind(`IA`).to(`A4`)).hasType(`BindingException`);
        });
    }
    
    test
    shared void boundInterfaceReturnsInstanceAsVariant() {
        
        value injector = oldSingleCreateInjector((binder)
            {
            binder.bind(`IA`).to(`A`);
            binder.bind(`IA`, "v1").to(`A0`);
            binder.bind(`IA`, "v2").to(`A2`);
        });
        
        value instance = injector.instance(`IA`);
        assertIs(instance, `A`);
        
        value instance0 = injector.instance(`IA`, "v1");
        assertIs(instance0, `A0`);
        
        value instance2 = injector.instance(`IA`, "v2");
        assertIs(instance2, `A2`);
        
        assertThatException(()=>injector.instance(`IA`, "novariant")).hasType(`BindingException`);
    }
    
    test
    shared void boundInterfaceReturnsSingletonAsDefault() {
        
        value injector = oldSingleCreateInjector((binder)
            {
            binder.bind(`IA`).to(`A`);
        });
        
        value instance = injector.instance(`IA`);
        assertIs(instance, `A`);
        
        value instance0 = injector.instance(`IA`);
        assertEquals(instance, instance0);
    }
    
    test
    shared void boundInterfaceReturnsSingleton() {
        
        value injector = oldSingleCreateInjector((binder)
            {
            binder.bind(`IA`).to(`A`, singleton);
        });
        
        value instance = injector.instance(`IA`);
        assertIs(instance, `A`);
        
        value instance0 = injector.instance(`IA`);
        assertEquals(instance, instance0);
    }
    
    test
    shared void boundInterfaceReturnsNoScope() {
        
        value injector = oldSingleCreateInjector((binder)
            {
            binder.bind(`IA`).to(`A`, noScope);
        });
        
        value instance = injector.instance(`IA`);
        assertIs(instance, `A`);
        
        value instance0 = injector.instance(`IA`);
        assertIs(instance, `A`);
        assertNotEquals(instance, instance0);
    }
    
    test
    shared void scopeWorksWithVariants() {
        
        value injector = oldSingleCreateInjector((binder)
            {
            binder.bind(`IA`, "v1").to(`A`, singleton);
            binder.bind(`IA`, "v2").to(`A`, singleton);
        });
        
        value instance1 = injector.instance(`IA`, "v1");
        assertIs(instance1, `A`);
        
        value instance2 = injector.instance(`IA`, "v2");
        assertIs(instance2, `A`);
        assertNotEquals(instance2, instance1);
        
        value instance3 = injector.instance(`IA`, "v1");
        assertEquals(instance3, instance1);
        
        value instance4 = injector.instance(`IA`, "v2");
        assertEquals(instance4, instance2);
    }
}

interface IA{}
class A() satisfies IA{}
class A0() satisfies IA{}
class A2 satisfies IA{shared new(){}}
class A3 satisfies IA{new(){}}
class A4 satisfies IA{shared new a(){}}
