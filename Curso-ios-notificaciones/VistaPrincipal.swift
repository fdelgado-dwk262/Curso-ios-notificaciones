//
//  ContentView.swift
//  Curso-ios-notificaciones
//
//  Created by Equipo 9 on 25/2/26.
//

import SwiftUI

struct VistaPrincipal: View {
    
    @Environment(NotificationManager.self) var manager
    
    @State private var horaProgramada = Date()
    @State private var recodatorio = "Commiteaaaa ar-🐐-vos"
    
    // el usuario puede rechazar los permisos
    // y se pide al usuario que los active
    // control
    @State private var mostrarAlertaAjustes = false
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Datos") {
                   TextField("Recordatorio", text: $recodatorio)
                    DatePicker("Hora", selection: $horaProgramada, displayedComponents: .hourAndMinute)
                }
                Section("Permisos") {
                    HStack {
                        Text("Estado de permisos:")
                        Spacer()
                        // TODO: mini vista para los permismos
                        VistaEstadoPermisos(status: manager.estadoDeLaAutorizacion)
                    }
                }
                
                //
                Section("En función del estado haremos varias cosas") {
                    Button("Programar aviso") {
                        // Hará varias cosas en función si estan o no las notificaciones habilitadas
                        programarAccionDeAviso()
                    }
                }
            }
            
        }
        .navigationTitle(Text("Notificaciones"))
        
        VStack {
            Image(systemName: "clock")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("La noticiación")
        }
        .padding()
    }
    
    // TODO: aquio seguimos
    func programarAccionDeAviso() {
        
    }
}

struct VistaDetalle: View {
    
    let texto: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundColor(.pink)
                .symbolEffect(.bounce)
            
            Text("¡Recortadotrio recibido!")
                .font(.title2)
                .bold()
            
            Text(texto)
                .font(.body)
                .padding()
                .background(Color.orange.opacity(0.2))
                .cornerRadius(10)
            
        }
        .navigationTitle("Recordatorio")
    }
}

struct VistaEstadoPermisos: View {
    let status : UNAuthorizationStatus
    
    var body: some View {
        switch status {
        case .authorized:
            Text("Permiso concedido").foregroundStyle(Color.green)
        case .denied:
            Text("Denegado").foregroundStyle(Color.red)
        case .notDetermined:
            Text("Pendiente").foregroundStyle(Color.orange)
        default:
            Text("Otros ...").foregroundStyle(Color.gray)
        }
    }
}


#Preview("vista rpincipal") {
    VistaPrincipal()
        .environment(NotificationManager())
}

#Preview("vista detalle") {
    return NavigationStack {
        VistaDetalle(texto: "Comitea ar-🐐-vos")
    }
    
}

#Preview("vista Estao Permisos") {
    VistaEstadoPermisos(status: .authorized)
}
