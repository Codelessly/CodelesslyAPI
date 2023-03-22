// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// This mixin is extended by every Undo Action and api models
/// so .toJson() can be called regardless of the class.
/// It is used for storing actions on server.
mixin SerializableMixin {
  /// Returns a serializable map representation of the object.
  Map toJson();
}
