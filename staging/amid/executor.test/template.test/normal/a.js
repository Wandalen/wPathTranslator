(function() {

console.log( 'a:before' );

//
//>-->//

include( 'b/b1.js' );
include( 'b/b2.js' );
include( 'b/b3.js' );

return `// a`
//<--<//
//

console.log( 'a:after' );

});
