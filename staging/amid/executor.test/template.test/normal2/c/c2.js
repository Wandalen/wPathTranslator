(function() {

console.log( 'c2:before' );

//
//>-->//

include( '../d/d1.js' );
include( '../d/d2.js' );
include( '../d/d3.js' );

return `// c2`
//<--<//
//

console.log( 'c2:after' );

});
