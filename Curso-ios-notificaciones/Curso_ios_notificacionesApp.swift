//
//  Curso_ios_notificacionesApp.swift
//  Curso-ios-notificaciones
//
//  Created by Equipo 9 on 25/2/26.
//

import SwiftUI

@main
struct Curso_ios_notificacionesApp: App {
    // instanciamos para paraserlo a la vista
    @State private var manager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            VistaPrincipal()
                .environment(manager)
        }
    }
}
