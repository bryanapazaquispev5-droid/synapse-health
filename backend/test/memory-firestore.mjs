export class MemoryFirestore {
  documents = new Map();
  tail = Promise.resolve();
  collection(name) { return {doc: id => this.ref(`${name}/${id}`)}; }
  ref(path) { return {path, get: async () => this.snapshot(path)}; }
  snapshot(path) {
    const data = this.documents.get(path);
    return {exists: data !== undefined, data: () => data};
  }
  runTransaction(callback) {
    const task = this.tail.then(async () => {
      const pending = [];
      const value = await callback({
        get: async ref => this.snapshot(ref.path),
        set: (ref, data) => pending.push([ref.path, data]),
        update: (ref, data) => pending.push([ref.path, {...this.documents.get(ref.path), ...data}]),
      });
      for (const [path, data] of pending) this.documents.set(path, data);
      return value;
    });
    this.tail = task.catch(() => {});
    return task;
  }
}
