(function() {

debugger;
console.log( 'b:before' );

//
//>-->//

include( 'a.js' );
include( 'c.js' );

return '// last line';
//<--<//
//

debugger;
console.log( 'b:after' );

});
