// .vuepress/config.js
module.exports = {
  title: "More Than Music with MIDI, Tiny Computers & JavaScript",
  serviceWorker: true,  
  themeConfig: {          
    editLinks: false,      
    nav: [        
         
        { text: 'More WebMIDI Resources', link: 'https://midi.mand.is' },                        
      ],
      sidebar: [  
        ["1-agenda", "Workshop Agenda"],
        ["2-midi-intro", "Introduction to MIDI"],
        ["3-circuit-playground", "Our Circuit Playgrounds"],
        // ["3-arduino-code", "Arduino Setup & Code"],
        ["4-javascript-code", "WebMIDI Setup & Test Code"],
        // ["5-webmidi-hello-world", "WebMIDI Hello World 🎹"],
        // ["6-midi-color-mixer", "WebMIDI Color Mier"],
        ["5-projects", "Let's Build Things!"],
        ["references", "Resources & Documentation"]        
      ]
    }
}