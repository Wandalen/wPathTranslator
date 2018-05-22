(function() {

console.log( 'a2:before' );

//
//>-->//

include( 'a1.js' );

return `// a2`
//<--<//
//

console.log( 'a2:after' );

});
