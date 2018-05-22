(function() {

debugger;
console.log( 'a:before' );

//
//>-->//

return `
console.log( ${_.toStr( __file.relative )} );
`

//<--<//
//

debugger;
console.log( 'a:after' );

});
