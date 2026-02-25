package com.smileproiz.handler;

import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

public class CartWebSocketHandler extends TextWebSocketHandler {

    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        System.out.println("Получено сообщение: " + message.getPayload());
        // Отправка подтверждения
        session.sendMessage(new TextMessage("{\"status\":\"ok\"}"));
    }
}
