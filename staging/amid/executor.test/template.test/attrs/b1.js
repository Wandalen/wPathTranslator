(function() {

debugger;
console.log( 'b:before' );

//
//>-->//

include( '/a.js' );

return '';
//<--<//
//

debugger;
console.log( 'b:after' );

});
