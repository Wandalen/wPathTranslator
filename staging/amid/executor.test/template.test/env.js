(function() {

debugger;
console.log( 'env:before' );

//
//>-->//

return `
console.log( '__dirname : ${__dirname}' );
console.log( '__filename : ${__filename}' );
console.log( ${_.toStr( __file.relative )} );
console.log( ${_.toStr( __fileFrame.file.relative )} );
console.log( ${_.toStr( __chunkFrame.fileFrame.file.relative )} );
`

//<--<//
//

debugger;
console.log( 'env:after' );

});
