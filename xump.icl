<?xml?>
<!--
    Copyright (c) 1996-2009 iMatix Corporation

    This file is licensed under the GPL as follows:

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or (at
    your option) any later version.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    For information on alternative licensing for OEMs, please contact
    iMatix Corporation.
 -->
<class
    name      = "xump"
    comment   = "Xump engine class"
    script    = "icl_gen"
    license   = "gpl"
    opaque    = "1"
    >
<doc>
The xump class implements the Xump engine.  To use Xump, create an instance
of this class.
</doc>

<inherit class = "xump_store_front" />

<import class = "asl" />
<import class = "xump_store" />
<import class = "xump_store_ram" />
<import class = "xump_queue" />

<context>
</context>

<method name = "new">
    <doc>
    Creates a new Xump engine instance.  Xump engines are unnamed containers
    for stores.
    </doc>
</method>

<method name = "destroy">
</method>

<method name = "set store" template = "function">
    <doc>
    Registers a store instance with the engine.  The caller is responsible
    for creating the store using a xump_store_xyz_xump_store_new () method.
    The engine will automatically destroy the store instance at shutdown
    time.
    </doc>
    <argument name = "store" type = "xump_store_t *" />
    //
    xump__xump_store_bind (self, store);
    xump_store_request_announce (store);
    xump_store_unlink (&store);
</method>

<method name = "store" return = "store">
    <doc>
    Returns the named store instance, or NULL if no such store was registered.
    </doc>
    <argument name = "self" type = "$(selftype) *">Reference to self</argument>
    <argument name = "name" type = "char *" />
    <declare name = "store" type = "xump_store_t *" default = "NULL" />
    <local>
    ipr_looseref_t
        *looseref;                      //  Store portals are in looseref list
    </local>
    //
    looseref = ipr_looseref_list_first (self->xump_store_list);
    while (looseref) {
        store = (xump_store_t *) (looseref->object);
        if (streq (store->name, name))
            break;                      //  We've found the matching store
        store = NULL;
        looseref = ipr_looseref_list_next (&looseref);
    }
</method>

<method name = "selftest">
    <local>
    xump_t
        *xump;
    xump_store_t
        *store;
    xump_queue_t
        *queue;
    </local>
    //
    xump = xump_new ();
    xump_set_store (xump, xump_store_ram__xump_store_new (NULL, "RAM1"));
    xump_set_store (xump, xump_store_ram__xump_store_new (NULL, "RAM2"));

    assert (xump_store (xump, "RAM1") != NULL);
    assert (xump_store (xump, "RAM0") == NULL);

    store = xump_store (xump, "RAM1");
    queue = xump_queue_new (store, "Test queue");

    //  Check that every methods fails properly
    assert (xump_queue_create (queue) == -1);
    assert (xump_queue_fetch  (queue) == -1);
    assert (xump_queue_update (queue) == -1);
    assert (xump_queue_delete (queue) == -1);

    xump_queue_destroy (&queue);
    xump_destroy (&xump);
</method>

</class>