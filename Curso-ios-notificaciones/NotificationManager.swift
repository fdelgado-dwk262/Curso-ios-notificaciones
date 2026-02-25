//
//  NotificacionManager.swift
//  Curso-ios-notificaciones
//
//  Created by Equipo 9 on 25/2/26.
//

import SwiftUI
import UserNotifications

@Observable
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    var estadoDeLaAutorizacion: UNAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        // un singelton .-
        UNUserNotificationCenter.current().delegate = self
        
        Task {
            await comprobarEstadoDePermisos()
        }
    }
    
    func comprobarEstadoDePermisos() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        self.estadoDeLaAutorizacion = settings.authorizationStatus
    }
    
}
