(function() {

console.log( 'b2:before' );

//
//>-->//

include( '../c/c1.js' );
include( '../c/c2.js' );
include( '../c/c3.js' );

return `// b2`
//<--<//
//

console.log( 'b2:after' );

});
