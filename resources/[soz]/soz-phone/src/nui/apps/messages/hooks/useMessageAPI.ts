import { useSnackbar } from '@os/snackbar/hooks/useSnackbar';
import { ServerPromiseResp } from '@typings/common';
import { Message, MessageConversationResponse, MessageEvents, PreDBMessage } from '@typings/messages';
import { fetchNui } from '@utils/fetchNui';
import { useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { useRecoilValueLoadable } from 'recoil';

import { useContactActions } from '../../contacts/hooks/useContactActions';
import { MockConversationServerResp } from '../utils/constants';
import { messageState, useSetMessages } from './state';
import { useMessageActions } from './useMessageActions';

type UseMessageAPIProps = {
    sendMessage: ({ conversationId, message }: PreDBMessage) => void;
    addConversation: (targetNumber: string) => void;
    deleteConversation: (conversationIds: string[]) => void;
    fetchMessages: (conversationId: string, page: number) => void;
};

export const useMessageAPI = (): UseMessageAPIProps => {
    const { addAlert } = useSnackbar();
    const [t] = useTranslation();
    const { updateLocalMessages, updateLocalConversations, removeLocalConversation } = useMessageActions();
    const navigate = useNavigate();
    const { state: messageConversationsState, contents: messageConversationsContents } = useRecoilValueLoadable(
        messageState.messageCoversations
    );
    const { getPictureByNumber, getDisplayByNumber } = useContactActions();
    const setMessages = useSetMessages();

    const sendMessage = useCallback(
        ({ conversationId, message }: PreDBMessage) => {
            fetchNui<ServerPromiseResp<Message>>(MessageEvents.SEND_MESSAGE, {
                conversationId,
                message,
            }).then(resp => {
                if (resp.status !== 'ok') {
                    return addAlert({
                        message: t('MESSAGES.FEEDBACK.NEW_MESSAGE_FAILED'),
                        type: 'error',
                    });
                }

                updateLocalMessages(resp.data);
            });
        },
        [updateLocalMessages, t, addAlert]
    );

    const addConversation = useCallback(
        (targetNumber: string) => {
            if (messageConversationsState !== 'hasValue') {
                return;
            }

            fetchNui<ServerPromiseResp<MessageConversationResponse>>(MessageEvents.CREATE_MESSAGE_CONVERSATION, {
                targetNumber,
            }).then(resp => {
                if (resp.status === 'error') {
                    navigate('/messages');
                    return addAlert({
                        message: t('MESSAGES.FEEDBACK.CONVERSATION_CREATE_ONE_NUMBER_FAILED', {
                            number: targetNumber,
                        }),
                        type: 'error',
                    });
                }

                const doesConversationExist = messageConversationsContents.find(
                    c => c.conversation_id === resp.data.conversation_id
                );

                if (doesConversationExist) {
                    navigate('/messages/conversations/' + resp.data.conversation_id);
                    return;
                }

                const display = getDisplayByNumber(resp.data.phoneNumber);
                const avatar = getPictureByNumber(resp.data.phoneNumber);

                updateLocalConversations({
                    phoneNumber: resp.data.phoneNumber,
                    conversation_id: resp.data.conversation_id,
                    updatedAt: resp.data.updatedAt,
                    display,
                    unread: 0,
                    avatar,
                });

                navigate(`/messages/conversations/${resp.data.conversation_id}`);
            });
        },
        [
            history,
            updateLocalConversations,
            addAlert,
            t,
            getDisplayByNumber,
            getPictureByNumber,
            messageConversationsContents,
            messageConversationsState,
        ]
    );

    const deleteConversation = useCallback(
        (conversationIds: string[]) => {
            fetchNui<ServerPromiseResp<void>>(MessageEvents.DELETE_CONVERSATION, {
                conversationsId: conversationIds,
            }).then(resp => {
                if (resp.status !== 'ok') {
                    return addAlert({
                        message: t('MESSAGES.DELETE_CONVERSATION_FAILED'),
                        type: 'error',
                    });
                }

                removeLocalConversation(conversationIds);
            });
        },
        [addAlert, t, removeLocalConversation]
    );

    const fetchMessages = useCallback(
        (conversationId: string, page: number) => {
            fetchNui<ServerPromiseResp<Message[]>>(
                MessageEvents.FETCH_MESSAGES,
                {
                    conversationId,
                    page,
                },
                MockConversationServerResp
            ).then(resp => {
                if (resp.status !== 'ok') {
                    addAlert({
                        message: t('MESSAGES.FEEDBACK.FETCHED_MESSAGES_FAILED'),
                        type: 'error',
                    });

                    return navigate('/messages');
                }

                setMessages(resp.data);
            });
        },
        [setMessages, addAlert, t, history]
    );

    return {
        sendMessage,
        deleteConversation,
        addConversation,
        fetchMessages,
    };
};