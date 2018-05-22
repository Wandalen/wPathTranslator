(function() {

debugger;
console.log( 'f1:before' );

//
//>-->//

var result = '';
for( var i = 0 ; i < 9 ; i++ )
result += i + ' ';

return `console.log( '${result}' );`;

//<--<//
//

debugger;
console.log( 'f1:after' );

});
