(function() {

console.log( 'b:before' );

//
//>-->//

include( 'a2.js' );

include( 'c/c1.js' );
include( 'c/c2.js' );
include( 'c/c3.js' );

return `// b`
//<--<//
//

console.log( 'b:after' );

});
