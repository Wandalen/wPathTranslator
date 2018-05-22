(function() {

debugger;
console.log( 'b:before' );

//
//>-->//

include( 'folder/d.js' );
include( '/folder/e.js' );

return '// last line';
//<--<//
//

debugger;
console.log( 'b:after' );

});
