import { createModel } from '@rematch/core';

import { ServerPromiseResp } from '../../../typings/common';
import { GalleryPhoto, PhotoEvents } from '../../../typings/photo';
import { MockPhotoData } from '../apps/photo/utils/constants';
import { fetchNui } from '../utils/fetchNui';
import { buildRespObj } from '../utils/misc';
import { RootModel } from '.';

export const photo = createModel<RootModel>()({
    state: [] as GalleryPhoto[],
    reducers: {
        set: (state, payload) => {
            return [...payload];
        },
        add: (state, payload) => {
            return [...state, payload];
        },
        remove: (state, payload) => {
            return [...state.filter(photo => photo.id !== payload)];
        },
    },
    effects: dispatch => ({
        async setPhotos(payload: GalleryPhoto[]) {
            dispatch.photo.set(payload);
        },
        async appendPhoto(payload: GalleryPhoto) {
            dispatch.photo.add(payload);
        },
        async removePhoto(payload: number) {
            dispatch.photo.remove(payload);
        },
        // loader
        async loadPhotos() {
            fetchNui<ServerPromiseResp<GalleryPhoto[]>>(
                PhotoEvents.FETCH_PHOTOS,
                undefined,
                buildRespObj(MockPhotoData)
            ).then(photos => {
                dispatch.photo.set(photos.data);
            });
        },
    }),
});