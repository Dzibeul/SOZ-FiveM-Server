import { ResultSetHeader } from 'mysql2';

import { DBSocietyUpdate, PreDBSociety, SocietyMessage } from '../../../typings/society';
import DbInterface from '../db/db_wrapper';

export class _SocietiesDB {
    async addSociety(identifier: string, { number, message, pedPosition }: PreDBSociety): Promise<number> {
        const query = `INSERT INTO phone_society_messages (conversation_id, source_phone, message, position) VALUES (?, ?, ?, ?)`;
        const [setResult] = await DbInterface._rawExec(query, [number, identifier, message, pedPosition]);

        return (<ResultSetHeader>setResult).insertId;
    }

    async updateMessage({ id, take, takenBy, takenByUsername, done }: DBSocietyUpdate): Promise<boolean> {
        const query = `UPDATE phone_society_messages SET isTaken=?, takenBy=?, takenByUsername=?, isDone=? WHERE id=?`;
        const [setResult] = await DbInterface._rawExec(query, [take, takenBy, takenByUsername, done, id]);
        return (<ResultSetHeader>setResult).affectedRows === 1;
    }

    async getMessage(id: number): Promise<SocietyMessage[]> {
        const query = `SELECT *, unix_timestamp(createdAt)*1000 as createdAt, unix_timestamp(updatedAt)*1000 as updatedAt FROM phone_society_messages WHERE id = ?`;
        const [result] = await DbInterface._rawExec(query, [id]);
        return <SocietyMessage[]>result;
    }

    async getMessages(identifier: string): Promise<SocietyMessage[]> {
        const query = `SELECT *, unix_timestamp(createdAt)*1000 as createdAt, unix_timestamp(updatedAt)*1000 as updatedAt FROM phone_society_messages WHERE conversation_id = ? AND updatedAt > date_sub(now(), interval 2 day)`;
        const [result] = await DbInterface._rawExec(query, [identifier]);
        return <SocietyMessage[]>result;
    }
}

const SocietiesDb = new _SocietiesDB();
export default SocietiesDb;