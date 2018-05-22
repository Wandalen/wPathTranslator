(function() {

console.log( 'a:before' );

//
//>-->//

include.ifAny = 'script.server';
include( 'c/**' );

include.ifAny = 'style';
debugger;
include( './c/**',function( o )
{
  debugger;
  o.result = `var style = ` + _.toJstruct( o.result ) + `;`
});

return `// a`
//<--<//
//

console.log( 'a:after' );

});
