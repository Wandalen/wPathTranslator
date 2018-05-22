(function() {

console.log( 'b1:before' );

//
//>-->//

include( 'b3.js' );
include( 'b3.js' );

return `// b1`
//<--<//
//

console.log( 'b1:after' );

});
