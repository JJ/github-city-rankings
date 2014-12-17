 #!/usr/bin/env coffee

city=process.argv[2]
fs = require 'fs'
ECT = require 'ect'
renderer = ECT({ root : 'layout' });

today = new Date()
from = new Date()
from.setYear today.getFullYear() - 1	

usuarios= [
        (
                lugar: 1
                nick: 'KK'
                contrib:2000
                stars:3
                lenguajes:'Brainfuck'
                location:'Polopos'
                avatar:"[uno](cosa.aqui)"
        )
        
        (
                lugar: 2
                nick: 'KKX'
                contrib:1000
                stars:5
                lenguajes:'PHP'
                location:'Marajena'
                avatar:"[dos](cosa.aqui)"
        )
        ]
                
data=
        start_date: from.toGMTString()
        end_date: from.toGMTString()
        usuarios: usuarios
        
console.log data             
console.log renderer.render('layout.ect', data )
