(function() {

console.log( 'a:before' );

//
//>-->//

include.ifAny = 'script.server';
include( 'c/**' );

include.ifAny = 'style';
include( './c/**',function( o )
{
  o.result = `var style = ` + _.toJstruct( o.result ) + `;`
});

return `// a`
//<--<//
//

console.log( 'a:after' );

});
