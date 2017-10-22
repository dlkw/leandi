import ceylon.language.meta.declaration {
    ValueDeclaration
}
shared final annotation class VariantAnnotation(shared String name)
        satisfies OptionalAnnotation<VariantAnnotation, ValueDeclaration>
{}

"This is experimental, use with caution."
shared annotation VariantAnnotation variant(String name)
{
    return VariantAnnotation(name);
}