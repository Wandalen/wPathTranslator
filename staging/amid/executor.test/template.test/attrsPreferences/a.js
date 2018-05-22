(function() {

console.log( 'a:before' );

//
//>-->//

include.ifAny = 'script.server';
include( 'c/**' );

return `// a`
//<--<//
//

console.log( 'a:after' );

});
