(function() {

console.log( 'a:before' );

//
//>-->//

include( 'c/c1.s' );
include( 'c/c2.js' );
include( 'c/c3.ss' );

return `// a`
//<--<//
//

console.log( 'a:after' );

});
