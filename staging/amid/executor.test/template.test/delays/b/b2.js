(function() {

console.log( 'b2:before' );

//
//>-->//

include( '../c/c1.js2' );
include( '../c/c2.js2' );
include( '../c/c3.js2' );

return `// b2`
//<--<//
//

console.log( 'b2:after' );

});
